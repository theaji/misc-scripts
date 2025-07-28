
public class greaterThan {
    public static int findLargest(int num1, int num2) {
                
        if (num1 > num2) {
			System.out.println(num1 + " is greater than " + num2);
			return num1;
			}
			else
			{
				System.out.println(num2 + " is greater than " + num1);
				return num2;
			}	
    }
    public static void main (String[] args){
		findLargest(8,10);
		}
}
